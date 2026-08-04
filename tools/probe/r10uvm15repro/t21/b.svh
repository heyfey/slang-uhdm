class Holder;
  Early p;
  extern function void mOut();
  function void mInline();
    Early c;
    c = new();
  endfunction
endclass

function void Holder::mOut();
  Early d;
  d = new();
endfunction

function void fPkgInB();
  Early f;
  f = new();
endfunction
