// r10v68 arm v4 — the PORT High_conn and HIER_PATH boundaries the earl61/64/
// 65/66/67 laws own, exercised with a GENVAR in every position, so that
// § genvarWholeCaRhsFold68 can be proved not to reach them.
// MEASUREMENT ONLY.
module v4_kid68 #(parameter int unsigned N = 1, parameter int unsigned DataBitWidth = 8)
  (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [7:0] o);
  assign o = a ^ b ^ {7'b0, c} ^ N[7:0] ^ DataBitWidth[7:0];
endmodule

interface v4_if68;
  typedef struct packed { logic [7:0] addr; logic [7:0] dat; } ent_t;
  ent_t [3:0] buf_q;
  logic [7:0] w;
endinterface

module v4_hc68 #(parameter int unsigned FlashWordsW = 7, parameter int unsigned PageW = 8)
  (input logic [7:0] din, output logic [7:0] dout);
  logic [7:0]  arr [0:7];
  logic [15:0] wide;
  logic [7:0]  o0, o1, o2, o3;
  logic [7:0]  hp0, hp1, hp2;

  typedef struct packed { logic [15:0] addr; } rb_t;
  rb_t [3:0] read_buf;

  for (genvar i = 0; i < 2; i++) begin : g_hc
    if (i >= 0) begin : b1
      // BARE genvar as a port actual (earl61 § connOperandOwnScopeBind61).
      v4_kid68 #(.N(i+1)) u_a (.a({7'b0, i[0]}), .b(arr[i]), .c(i[0]), .o(o0));
      // genvar as an INDEX in a port actual.
      v4_kid68 u_b (.a(arr[i]), .b(wide[i +: 8]), .c(arr[i][0]), .o(o1));
      // genvar inside an OPERATION in a port actual.
      v4_kid68 u_c (.a(arr[i] + 8'd1), .b({4'b0, i[3:0]}), .c(1'b0), .o(o2));
      // whole-Rhs cont_assign in the SAME scope (the law's own cell).
      assign hp0 = i;
      // HIER_PATH with a genvar element index + an indexed part select
      // (earl68's declared R0 family: the vpiName re-render).
      assign hp1 = read_buf[i].addr[FlashWordsW +: PageW];
      assign hp2 = read_buf[i].addr[7 +: 8];
    end
  end

  v4_kid68 u_d (.a(din), .b(8'd0), .c(1'b0), .o(o3));
  assign dout = o0 ^ o1 ^ o2 ^ o3 ^ hp0 ^ hp1 ^ hp2 ^ din;
endmodule
