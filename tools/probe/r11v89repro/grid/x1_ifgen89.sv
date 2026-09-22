// r11v89 break arm v1 — THE OTHER TWO HOMES `red87HopHomeIsInstance87`
// ACCEPTS.  LAW A's recursion and LAW B's fence relaxation both key on
// `InstanceBody || GenerateBlock`, which is an INTERFACE and a GENERATE
// BLOCK as well as a module.  Does Surelog's `instance->setValue` road run
// there too?
package x1p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
endpackage
interface x1_if;
  localparam int           IC1 = 16'd5;
  localparam logic [7:0]   IC2 = IC1;     // LAW A, interface home
  localparam logic [95:0]  IW  = 96'd12;  // LAW B, interface home
  localparam logic [95:0]  IO  = 96'o17;
  localparam x1p::t A = '{bail: 8'hxA, a: IC1, b: IC2, c: IW, d: IO,
                          e: IC2, f: IW, g: IC1};
endinterface
module x1_ifgen89;
  x1_if u1();
  if (1) begin : g
    localparam int          GC1 = 16'd5;
    localparam logic [7:0]  GC2 = GC1;    // LAW A, generate home
    localparam logic [95:0] GW  = 96'd12; // LAW B, generate home
    localparam logic [95:0] GO  = 96'o17;
    localparam x1p::t B = '{bail: 8'hxA, a: GC1, b: GC2, c: GW, d: GO,
                            e: GC2, f: GW, g: GC1};
    x1_sink #(.R(B)) s2();
  end
  for (genvar i = 0; i < 1; i++) begin : h
    localparam int          HC1 = 16'd5;
    localparam logic [7:0]  HC2 = HC1;
    localparam logic [95:0] HW  = 96'd12;
    localparam x1p::t C = '{bail: 8'hxA, a: HC1, b: HC2, c: HW, d: HC2,
                            e: HW, f: HC1, g: HC2};
    x1_sink #(.R(C)) s3();
  end
endmodule
module x1_sink #(parameter x1p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
