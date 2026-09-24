// v11u77 va -- LAW B face: a NET-DECLARED aggregate whose members are NOT all
// logic.  elabSignal step (1) sets isNet TRUE from the net keyword and step
// (2) only flips it back to TRUE for an all-logic struct -- it never sets it
// FALSE for a struct with an int member.  hoistKind77 tests the struct BEFORE
// it tests isNetDecl77, so a `wire si_t` becomes StructVar.  Asked of golden.
package pn;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } sl_t;
  typedef struct packed { int x; logic [7:0] y; }         si_t;
  typedef union  packed { logic [15:0] a; logic [15:0] b; } un_t;
  typedef enum logic [1:0] { EA, EB } en_t;
  wire sl_t  n_wsl;     // all-logic struct, NET-declared
  wire si_t  n_wsi;     // int-member struct, NET-declared
  wire un_t  n_wun;     // packed UNION, NET-declared
  wire en_t  n_wen;     // enum, NET-declared
  si_t       v_si;      // the VARIABLE twin
  un_t       v_un;      // the VARIABLE twin
endpackage

module dut (output logic [31:0] o);
  import pn::*;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] n_wsl; assign n_wsl = 32'd1;
    logic [31:0] n_wsi; assign n_wsi = 32'd2;
    logic [31:0] n_wun; assign n_wun = 32'd3;
    logic [31:0] n_wen; assign n_wen = 32'd4;
    logic [31:0] v_si;  assign v_si  = 32'd5;
    logic [31:0] v_un;  assign v_un  = 32'd6;
  end
  assign o = gv[0].n_wsl ^ gv[0].n_wsi ^ gv[0].n_wun ^ gv[0].n_wen
           ^ gv[0].v_si  ^ gv[0].v_un;
endmodule
