// r10svs8 VERIFIER ARM v2 -- the PACKAGE-QUALIFIED RECEIVER cell.
//
// The class-method arm the patch widens has an EARLY RETURN before every other
// shape:  `if (isPkgQualifiedVarRef(recv0)) return emitExpr(recv0, ...);`
// -- i.e. the whole call COLLAPSES to the receiver reference and the method and
// its arguments are DROPPED.  That branch was written for class handles.  With
// the widening it is now reachable by covergroup built-ins for the first time,
// and the implementer's grid never writes a package-qualified receiver.
//
// W1  pk8::cgh8.sample();     package-qualified covergroup handle, STATEMENT
// W2  pk8::ch8.touch();       IN-LAW control: the same shape on a class handle
package pk8;
  int gq8;
  covergroup cgpk8;
    cppk8 : coverpoint gq8;
  endgroup
  cgpk8 cgh8 = new;

  class ktgt8;
    int u8;
    function void touch();
      u8 = 1;
    endfunction
  endclass
  ktgt8 ch8 = new;
endpackage

module v2;
  task w1_8();
    pk8::cgh8.sample();
  endtask

  task w2_8();
    pk8::ch8.touch();
  endtask
endmodule
