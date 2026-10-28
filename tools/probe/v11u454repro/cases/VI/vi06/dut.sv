// § ifcTaskFixupWalksAllStmts454
interface ifc(input logic clk);
  logic r;
  function automatic logic ok();
    if (r) return 1'b1;
    else return r;
  endfunction
endinterface
module top(input logic clk);
  ifc ia[2](clk);
  logic o;
  initial o = ia[0].ok();
endmodule
