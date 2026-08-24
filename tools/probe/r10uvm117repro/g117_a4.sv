// r10uvm117 arm a4 — THE NEGATIVE CONTROL for the hoisting shape.  The SAME
// free package function, in a file where NO module imports the package at file
// scope: one module imports it INSIDE its body, one names the function through
// its package scope and imports nothing.  MEASUREMENT ONLY.
package pk117d;
  function automatic void noHoistFn117d();
    process noHoistAlpha;
    noHoistAlpha = process::self();
  endfunction
endpackage

module bodyImp117d;
  import pk117d::*;
  initial noHoistFn117d();
endmodule

module scopedOnly117d;
  initial pk117d::noHoistFn117d();
endmodule

module nothing117d;
  initial begin end
endmodule
