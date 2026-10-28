// § ifcTaskFixupWalksAllStmts454
interface ifc;
  logic a, b;
  task automatic t(output logic a);
    if (b) a = 1;
    else a = 0;
    case (b) 1'b1: a = b; endcase
  endtask
endinterface
module top;
  ifc i();
  logic z;
  initial i.t(z);
endmodule
