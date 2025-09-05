(function(){
  const g = document.getElementById("grid");
  const notesEl = document.getElementById("notes");
  const statsEl = document.getElementById("stats");
  const searchEl = document.getElementById("search");
  const rows = cssVar("--r", 9), cols = cssVar("--c", 21);
  let cycle=[3,6,9], idx=0, allNotes=[];
  for(let r=0;r<rows;r++){
    for(let c=0;c<cols;c++){
      const el=document.createElement("div");
      const k=cycle[idx++%cycle.length];
      el.className="cell"; el.dataset.k=k; g.appendChild(el);
    }
  }
  fetch("./notes/index.json").then(r=>r.ok?r.json():[]).then(list=>{
    allNotes = list;
    statsEl.textContent = `${list.length} notes`;
    renderNotes(allNotes);
  }).catch(()=>{});
  
  function renderNotes(notes) {
    notesEl.innerHTML = '';
    // Sort notes by day number for better organization
    const sortedList = notes.sort((a, b) => {
      const dayA = parseInt(a.title.match(/Day (\d+)/)?.[1] || '0');
      const dayB = parseInt(b.title.match(/Day (\d+)/)?.[1] || '0');
      return dayA - dayB;
    });
    sortedList.forEach(n=>{ notesEl.appendChild(card(n)); });
  }
  
  // Add search functionality
  searchEl.addEventListener('input', (e) => {
    const query = e.target.value.toLowerCase();
    const filtered = allNotes.filter(note => 
      note.title.toLowerCase().includes(query) || 
      note.summary.toLowerCase().includes(query)
    );
    renderNotes(filtered);
    statsEl.textContent = `${filtered.length} of ${allNotes.length} notes`;
  });
  document.getElementById("shuffle").addEventListener("click",()=>{
    // 3-6-9 vortex math patterns
    const patterns = [
      { gap: "9px", cell: "27px", radius: "9px", cols: 27 }, // 3×9 pattern
      { gap: "6px", cell: "18px", radius: "6px", cols: 18 }, // 3×6 pattern  
      { gap: "12px", cell: "36px", radius: "12px", cols: 36 }, // 3×12 pattern
      { gap: "15px", cell: "45px", radius: "15px", cols: 45 }, // 3×15 pattern
    ];
    
    const pattern = patterns[Math.floor(Math.random() * patterns.length)];
    setVar("--gap", pattern.gap);
    setVar("--cell", pattern.cell);
    setVar("--radius", pattern.radius);
    setVar("--c", pattern.cols);
    
    // Regenerate grid with new pattern
    g.innerHTML = '';
    const newCols = pattern.cols;
    for(let r=0;r<rows;r++){
      for(let c=0;c<newCols;c++){
        const el=document.createElement("div");
        const k=cycle[idx++%cycle.length];
        el.className="cell"; el.dataset.k=k; g.appendChild(el);
      }
    }
    idx = 0; // Reset cycle index
  });
  function card(n){ 
    const el=document.createElement("article"); 
    el.className="note";
    el.style.cursor = "pointer";
    
    const h=document.createElement("h3"); 
    h.textContent=n.title;
    el.appendChild(h);
    
    const p=document.createElement("p"); 
    p.textContent=n.summary;
    el.appendChild(p);
    
    // Add day number badge
    const dayMatch = n.title.match(/Day (\d+)/);
    if (dayMatch) {
      const badge = document.createElement("span");
      badge.textContent = `Day ${dayMatch[1]}`;
      badge.style.cssText = "background: var(--accent); color: white; padding: 2px 6px; border-radius: 12px; font-size: 11px; font-weight: bold; margin-top: 8px; display: inline-block;";
      el.appendChild(badge);
    }
    
    // Make card clickable to view full entry
    el.addEventListener('click', () => {
      const dayNum = dayMatch ? dayMatch[1] : '1';
      const slug = `d${dayNum}-c1`; // Default to first commit of the day
      window.open(`./notes/${slug}/index.md`, '_blank');
    });
    
    return el; 
  }
  function cssVar(name, fb){
    const v=getComputedStyle(document.documentElement).getPropertyValue(name).trim();
    return v? parseInt(v,10) : fb;
  }
  function setVar(name, v){ document.documentElement.style.setProperty(name, v); }
})();
