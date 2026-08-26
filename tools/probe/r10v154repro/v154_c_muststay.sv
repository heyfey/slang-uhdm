// r10v154 arm C — MUST-STAY controls for every enum-constant precedent this
// law's surface sits on, plus the brief's "an enum used as a parameter value,
// a case selector, a port default and an array index".
//
// Nothing in this file may move between the pristine and the shipped binary
// EXCEPT the negative bare-decimal members the law owns, and those may move
// only TOWARD golden.  The based/sized/unbased-unsized encodings belong to
// § enumSubstIntConst30 / § enumCastInitNotEvaluated / the digits branch and
// must be byte-identical.
package guardpkg;
  parameter int SPAN_W = 2;
  // uvm_tlm_response_status_e's shape: no base, five written negatives that
  // the pristine binary ALREADY valued correctly (census: 126 cells, all SAME).
  typedef enum { RSP_OK = 1, RSP_NONE = 0, RSP_GENERIC = -1, RSP_ADDR = -2,
                 RSP_CMD = -3, RSP_BURST = -4, RSP_BYTEEN = -5 } rsp_status_e;
  // encodings other passes own — every one of these must stay put.
  typedef enum bit [3:0] { ENC_BASED = 4'd3, ENC_BIN = 4'b0101, ENC_HEX = 4'hA,
                           ENC_OCT = 4'o7, ENC_UNBASED = '0 } enc_kind_e;
  typedef enum bit [3:0] { ENC_CONCAT = {2'b10, 2'b01}, ENC_AFTER } cat_kind_e;
  typedef enum int { ENC_REF = SPAN_W, ENC_SUM = SPAN_W + 1, ENC_SHL = 1 << 3 } ref_kind_e;
  typedef enum int { ENC_CAST = int'(3), ENC_CASTB = 5 } cast_kind_e;
  // the implicit successor of a negative — golden's counter reads 1 in the def
  // view and 0 elaborated; the law abstains on every unwritten member.
  typedef enum int { SUC_HEAD = -1, SUC_NEXT, SUC_LAST } suc_kind_e;
  // the enum the consumers below use as a parameter value / case selector /
  // port default / array index.
  typedef enum bit [31:0] { PICK_LOW = -1, PICK_MID = 3, PICK_HIGH = 7 } pick_e;
  parameter pick_e PICK_DEFAULT = PICK_MID;
endpackage
module picker #(parameter guardpkg::pick_e PSEL = guardpkg::PICK_HIGH)
  (input logic clk_i, output logic [7:0] data_o);
  import guardpkg::*;
  logic [7:0] lut_mem [0:7];
  pick_e chosen;
  always_comb begin
    case (chosen)
      PICK_LOW  : data_o = 8'h01;
      PICK_MID  : data_o = lut_mem[PICK_MID];
      PICK_HIGH : data_o = lut_mem[PICK_HIGH];
      default   : data_o = 8'h00;
    endcase
  end
endmodule
module dut_muststay;
  import guardpkg::*;
  logic clk; logic [7:0] dat;
  rsp_status_e r; enc_kind_e e; cat_kind_e c; ref_kind_e f; cast_kind_e g; suc_kind_e s;
  picker #(.PSEL(guardpkg::PICK_LOW)) u_pick (.clk_i(clk), .data_o(dat));
  initial begin r = RSP_GENERIC; e = ENC_BASED; c = ENC_CONCAT; f = ENC_REF; g = ENC_CAST; s = SUC_HEAD; end
endmodule
