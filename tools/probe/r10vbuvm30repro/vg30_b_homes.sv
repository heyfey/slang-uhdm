package pv30b;
  class cv30bp;
    int m;
    function int inb(); return (m == -1); endfunction
    extern function int oob();
  endclass
  function int cv30bp::oob(); return (m == -1); endfunction
  function int pkgf30(); return (1 == -1); endfunction
  function automatic int pkgfa30(); return (1 == -1); endfunction
  function static int pkgfs30(); return (1 == -1); endfunction
endpackage

module mv30b;
  int m;
  function int modf(); return (m == -1); endfunction
  class cv30bm;
    int mm;
    function int inb(); return (mm == -1); endfunction
  endclass
  if (1) begin : gblk
    function int genf(); return (m == -1); endfunction
  end
  int x;
  initial x = modf() + gblk.genf();
endmodule

interface iv30b;
  int m;
  function int ifn(); return (m == -1); endfunction
endinterface

program pv30bprog;
  int m;
  function int prgf(); return (m == -1); endfunction
  initial m = prgf();
endprogram
