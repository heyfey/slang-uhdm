// § strLitShiftNeedsBacktick220
package p;
  function automatic string f();
    string s;
    s = "p\\q\n";
    return s;
  endfunction
endpackage
module top(output string o);
  initial o = p::f();
endmodule
