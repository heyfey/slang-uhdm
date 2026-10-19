// § enumRangedMemberSurelogVal412
module top(output logic [31:0] o);
  function automatic int f();
    enum {K, L=7, M} q;
    q = M;
    return q;
  endfunction
  assign o = f();
endmodule
