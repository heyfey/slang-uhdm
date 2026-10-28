// § ifcTaskFixupWalksAllStmts454
interface ifc;
  logic [1:0] sel, a, b;
  logic o;
  task automatic t();
    case (sel)
      a: o = 1;
      b, 2'd3: o = 0;
      default: o = sel[0];
    endcase
    casez (sel)
      2'b1?: o <= a[0];
    endcase
  endtask
endinterface
module top;
  ifc i();
  initial i.t();
endmodule
