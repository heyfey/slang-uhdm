// r11u83 i8 -- the MODULE twin of i1_ifkinds: the pass-77/79 ground, carried
// here as the in-family CONTROL.  Its listing must not move by one byte.
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } st_t;
  typedef struct packed { int unsigned q; logic [3:0] r; } si_t;
  typedef enum logic [1:0] { E0, E1 } e_t;
  wire  [31:0] n_plain;
  wire         n_scalar;
  tri   [31:0] n_tri;
  wire  st_t   n_wstruct;
  logic [15:0] v_plain;
  st_t         v_struct;
  si_t         v_structi;
  e_t          v_enum;
  int          v_int;
  logic [1:0][7:0] v_pkd;
endpackage

module dut (output logic [31:0] o);
  import pk::*;
  logic [31:0] m_own;
  if (1) begin : gm
    logic [31:0] n_plain;   assign n_plain   = 32'd1;
    logic [31:0] n_scalar;  assign n_scalar  = 32'd2;
    logic [31:0] n_tri;     assign n_tri     = 32'd3;
    logic [31:0] n_wstruct; assign n_wstruct = 32'd4;
    logic [31:0] v_plain;   assign v_plain   = 32'd5;
    logic [31:0] v_struct;  assign v_struct  = 32'd6;
    logic [31:0] v_structi; assign v_structi = 32'd7;
    logic [31:0] v_enum;    assign v_enum    = 32'd8;
    logic [31:0] v_int;     assign v_int     = 32'd9;
    logic [31:0] v_pkd;     assign v_pkd     = 32'd10;
  end
  assign o = m_own;
endmodule
