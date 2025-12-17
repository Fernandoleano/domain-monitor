document.addEventListener('DOMContentLoaded', async () => {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  
  // UI Elements
  const urlDisplay = document.getElementById('url-display');
  const addView = document.getElementById('add-view');
  const statsView = document.getElementById('stats-view');
  const monitorBtn = document.getElementById('monitor-btn');
  const statusDiv = document.getElementById('status');
  
  // Stats Elements
  const statusRing = document.getElementById('status-ring');
  const siteStatus = document.getElementById('site-status');
  const uptimeVal = document.getElementById('uptime-val');
  const latencyVal = document.getElementById('latency-val');
  const historyLink = document.getElementById('history-link');

  if (tab && tab.url) {
    const url = new URL(tab.url);
    const cleanUrl = url.origin;
    urlDisplay.textContent = cleanUrl;

    // 1. Check if site is already monitored
    try {
      const lookupResp = await fetch(`http://localhost:3000/sites/lookup.json?url=${encodeURIComponent(cleanUrl)}`, {
        method: 'GET',
        headers: { 'Accept': 'application/json' }
      });
      
      const lookupData = await lookupResp.json();

      if (lookupResp.ok && lookupData.found) {
        // --- SHOW STATS VIEW ---
        addView.style.display = 'none';
        statsView.style.display = 'block';
        
        const site = lookupData.site;
        const isUp = site.status === 'up';
        
        // Update Header to show Name instead of URL
        urlDisplay.textContent = site.name || url.hostname;
        urlDisplay.style.fontWeight = "bold";
        urlDisplay.style.fontSize = "14px";
        
        // Update Ring with Favicon (Logo)
        statusRing.className = `status-ring ${isUp ? 'ring-up' : 'ring-down'}`;
        statusRing.innerHTML = `<img src="https://www.google.com/s2/favicons?domain=${encodeURIComponent(cleanUrl)}&sz=128" style="width: 32px; height: 32px; border-radius: 4px;">`;
        
        // Update Text
        siteStatus.textContent = isUp ? 'Operational' : 'Down';
        siteStatus.style.color = isUp ? '#10b981' : '#f43f5e';
        
        // Update Metrics
        uptimeVal.textContent = `${lookupData.uptime}%`;
        latencyVal.textContent = `${lookupData.avg_latency}ms`;
        
        // Link
        historyLink.href = `http://localhost:3000/sites/${site.id}`;

      } else {
        // --- SHOW ADD VIEW ---
        addView.style.display = 'block';
        statsView.style.display = 'none';
      }
    } catch (e) {
      console.error("Lookup failed", e);
      // Default to Add View on error, maybe show network error
      addView.style.display = 'block';
    }

    // 2. Add Site Logic
    monitorBtn.addEventListener('click', async () => {
      monitorBtn.disabled = true;
      monitorBtn.textContent = "Adding...";
      statusDiv.style.display = 'none';

      try {
        const response = await fetch('http://localhost:3000/sites.json', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            site: {
              url: cleanUrl,
              name: url.hostname.replace('www.', ''),
              check_interval: 10,
              active: true
            }
          })
        });

        const data = await response.json();

        if (response.ok) {
          statusDiv.textContent = "Success! Reloading...";
          statusDiv.className = "success";
          statusDiv.style.display = 'block';
          
          // Reload popup to trigger lookup and show stats
          setTimeout(() => {
            window.location.reload();
          }, 1000);
          
        } else {
          throw new Error(data.errors ? data.errors.join(', ') : 'Failed to add site');
        }
      } catch (error) {
        statusDiv.textContent = "Error: " + error.message;
        statusDiv.className = "error";
        statusDiv.style.display = 'block';
        monitorBtn.disabled = false;
        monitorBtn.textContent = "Try Again";
      }
    });

  } else {
    urlDisplay.textContent = "Cannot monitor this page.";
    monitorBtn.disabled = true;
  }
});
