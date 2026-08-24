// v82 adversarial arm V4 — THE CONSUMER AXIS WITH AN *OVERRIDDEN* PARAMETER.
// The pass's consumer arm (g2) uses a non-overridden PACKAGE localparam, so
// none of these consumers ever met the new `ovW82` arm.  Part-select,
// indexed part-select, case item, call argument, concat member, replication,
// High_conn (earl81's must-stay-64 family), unpacked dim, bit-select index.
// MEASUREMENT ONLY.
package pkv4_82;
  localparam int PKI = 8;
endpackage

module sink_v4_82 #(parameter int SW = 1) (input logic [SW:0] d, output logic o);
  assign o = ^d;
endmodule

module ch_v4_82 #(parameter int CW = 1) (input logic clk, output logic o);
  logic [63:0] bus;
  logic [3:0]  arr [15:0];
  logic        acc;
  function automatic logic f_v4(input int a);
    return a[0];
  endfunction
  // packed range (the law's own consumer)
  logic [CW:0] n_r;
  // unpacked range-form + size-form dims
  logic [3:0]  u_r [CW:0];
  logic [3:0]  u_s [CW];
  // High_conn: earl81's must-stay-64 family
  sink_v4_82 #(.SW(CW)) i_s (.d(bus[CW:0]), .o(o));
  always_comb begin
    acc = clk;
    acc = acc ^ (^bus[CW:0]);      // part-select bound
    acc = acc ^ (^bus[CW +: 4]);   // indexed part-select base
    acc = acc ^ bus[CW];           // bit-select index
    acc = acc ^ arr[0][0];
    acc = acc ^ f_v4(CW);          // call argument
    acc = acc ^ {CW[0], clk};      // concat member
    acc = acc ^ (^{4{CW[0]}});     // replication
    acc = acc ^ (CW > 3);          // plain expression operand
    case (CW)                       // case item is the SELECTOR here
      8: acc = acc ^ 1'b1;
      default: acc = acc ^ 1'b0;
    endcase
    case (clk)
      1'b1: acc = acc ^ CW[0];
      default: acc = acc ^ 1'b0;
    endcase
    acc = acc ^ n_r[0] ^ u_r[0][0] ^ u_s[0][0];
  end
endmodule

module top_v4_82 (input logic clk, output logic o1, o2, o3);
  localparam int EXPR_LPV = 4 + 4;
  localparam int LIT_LPV  = 8;
  ch_v4_82 #(.CW(EXPR_LPV))        ia (.clk(clk), .o(o1));
  ch_v4_82 #(.CW(pkv4_82::PKI))    ib (.clk(clk), .o(o2));
  ch_v4_82 #(.CW(LIT_LPV))         ic (.clk(clk), .o(o3));
endmodule
