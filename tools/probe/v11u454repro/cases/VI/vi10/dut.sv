// § ifcTaskFixupWalksAllStmts454
module top;
  ifc_g #(4) g();
  logic o;
  initial o = g.chk();
endmodule
interface ifc_g #(parameter W = 2);
  logic [W-1:0] v;
  for (genvar k = 0; k < 1; k++) begin : gg
    logic w;
  end
  function automatic logic chk();
    if (v == '0) return 1'b0;
    return v[0];
  endfunction
endinterface
