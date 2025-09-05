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
    const gaps=[8,10,12,14], cells=[20,22,24,26], rads=[4,6,8,10];
    setVar("--gap", gaps[Math.floor(Math.random()*gaps.length)]+"px");
    setVar("--cell", cells[Math.floor(Math.random()*cells.length)]+"px");
    setVar("--radius", rads[Math.floor(Math.random()*rads.length)]+"px");
  });
  function card(n){ 
    const el=document.createElement("article"); 
    el.className="note";
    
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
    
    return el; 
  }
  function cssVar(name, fb){
    const v=getComputedStyle(document.documentElement).getPropertyValue(name).trim();
    return v? parseInt(v,10) : fb;
  }
  function setVar(name, v){ document.documentElement.style.setProperty(name, v); }
})();
