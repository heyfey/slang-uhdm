// r11u88 q12 -- LAW C: HOW the producer SPELLS the folded net-decl-assign RHS
// when the initializer is a plain NAME.  Six written encodings of the same
// kind of read, one net each, so the table is read off golden and not guessed.
package pk;
  typedef enum logic [3:0] { EA, EB = 2 } e_t;
  localparam int      P_DEC = 7;
  localparam logic [7:0] P_HEX = 8'hA;
  localparam int      P_NEG = -3;
endpackage

interface ifc ();
  localparam int         K_DEC = 5;
  localparam logic [7:0] K_HEX = 8'h1F;
  localparam logic [3:0] K_BIN = 4'b0110;
  localparam int         K_NEG = -4;
  localparam int         K_EXPR = 2 + 3;
  wire [31:0] w_kdec  = K_DEC;
  wire [7:0]  w_khex  = K_HEX;
  wire [3:0]  w_kbin  = K_BIN;
  wire signed [31:0] w_kneg = K_NEG;
  wire [31:0] w_kexpr = K_EXPR;
  wire [3:0]  w_enum  = pk::EB;
  wire [7:0]  w_wnar  = K_DEC;
  wire [31:0] w_wwide = K_HEX;
  wire [31:0] w_ewide = pk::EB;
  wire [31:0] w_pwide = pk::P_HEX;
  wire [31:0] w_lit8  = 8'd7;
  wire [31:0] w_pdec  = pk::P_DEC;
  wire [7:0]  w_phex  = pk::P_HEX;
  wire signed [31:0] w_pneg = pk::P_NEG;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.w_kdec ^ {24'd0, u_if.w_khex} ^ {28'd0, u_if.w_kbin} ^
             u_if.w_kneg ^ u_if.w_kexpr ^ {28'd0, u_if.w_enum} ^
             u_if.w_pdec ^ {24'd0, u_if.w_phex} ^ u_if.w_pneg ^
             {24'd0, u_if.w_wnar} ^ u_if.w_wwide ^ u_if.w_ewide ^
             u_if.w_pwide ^ u_if.w_lit8;
endmodule
