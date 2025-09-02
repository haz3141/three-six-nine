(function(){
  const g = document.getElementById("grid");
  const notesEl = document.getElementById("notes");
  const statsEl = document.getElementById("stats");
  const rows = cssVar("--r", 9), cols = cssVar("--c", 21);
  let cycle=[3,6,9], idx=0;
  for(let r=0;r<rows;r++){
    for(let c=0;c<cols;c++){
      const el=document.createElement("div");
      const k=cycle[idx++%cycle.length];
      el.className="cell"; el.dataset.k=k; g.appendChild(el);
    }
  }
  fetch("./notes/index.json").then(r=>r.ok?r.json():[]).then(list=>{
    statsEl.textContent = `${list.length} notes`;
    list.forEach(n=>{ notesEl.appendChild(card(n)); });
  }).catch(()=>{});
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
    
    // Add a link to view the full entry
    const link=document.createElement("a");
    link.href="#"; 
    link.textContent="View full research entry →";
    link.style.color="var(--accent)";
    link.style.textDecoration="none";
    link.style.fontSize="13px";
    link.style.marginTop="8px";
    link.style.display="block";
    el.appendChild(link);
    
    return el; 
  }
  function cssVar(name, fb){
    const v=getComputedStyle(document.documentElement).getPropertyValue(name).trim();
    return v? parseInt(v,10) : fb;
  }
  function setVar(name, v){ document.documentElement.style.setProperty(name, v); }
})();
