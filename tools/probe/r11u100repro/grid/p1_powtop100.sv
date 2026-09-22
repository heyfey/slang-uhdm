// r11u100 arm p1 — LAW A, `vpiPowerOp` AT THE TOP of a package parameter.
// `ExprEval.cpp:3765-3785` mints `INT:` + `static_cast<int64_t>(std::pow<int64_t>(..))`
// in the same three lines as the landed mult/div/mod arms, and its VALUE runs
// in `double` with ONE narrowing — § patPowCastArtefact73's ground.  The grid
// crosses base x exponent x declared width, inside the range where the double
// rounds and past it where the cast writes the indefinite pattern.
package p1p;
  localparam int     CPOW   = 2 ** 3;
  localparam int     CPOW0  = 2 ** 0;
  localparam int     CPOW1  = 7 ** 1;
  localparam int     CPOWZ  = 0 ** 3;
  localparam int     CPOWO  = 1 ** 31;
  localparam longint PBIG40 = 2 ** 40;
  localparam longint PBIG62 = 2 ** 62;
  localparam longint PB63   = 2 ** 63;
  localparam longint PB64   = 2 ** 64;
  localparam longint PB70   = 2 ** 70;
  localparam longint P339   = 3 ** 39;
  localparam longint P340   = 3 ** 40;
  localparam longint P527   = 5 ** 27;
  localparam longint P723   = 7 ** 23;
  localparam longint P1019  = 10 ** 19;
  localparam longint PNEG   = (-3) ** 41;
  localparam longint PNEG2  = (-2) ** 3;
  localparam int     PNARR  = 100 ** 3;
  localparam byte    PBY    = 5 ** 3;
  localparam logic [7:0] PU8 = 10 ** 3;
  localparam longint PNAME  = CPOW ** 2;
  localparam longint PPAR   = (2 ** 3);
  // the LIVE CONTROLS — no power at the top
  localparam int     CMUL   = 2 * 3;
  localparam int     CADD   = 1 + 2;
  localparam int     CLIT   = 6;
  localparam int     APOWL  = (2 ** 3) + 1;
  localparam int     CPOWC  = int'(2 ** 3);
endpackage
module p1_powtop100 (output logic [63:0] o);
  wire signed [63:0] wCPOW   = p1p::CPOW;
  wire signed [63:0] wCPOW0  = p1p::CPOW0;
  wire signed [63:0] wCPOW1  = p1p::CPOW1;
  wire signed [63:0] wCPOWZ  = p1p::CPOWZ;
  wire signed [63:0] wCPOWO  = p1p::CPOWO;
  wire signed [63:0] wPBIG40 = p1p::PBIG40;
  wire signed [63:0] wPBIG62 = p1p::PBIG62;
  wire signed [63:0] wPB63   = p1p::PB63;
  wire signed [63:0] wPB64   = p1p::PB64;
  wire signed [63:0] wPB70   = p1p::PB70;
  wire signed [63:0] wP339   = p1p::P339;
  wire signed [63:0] wP340   = p1p::P340;
  wire signed [63:0] wP527   = p1p::P527;
  wire signed [63:0] wP723   = p1p::P723;
  wire signed [63:0] wP1019  = p1p::P1019;
  wire signed [63:0] wPNEG   = p1p::PNEG;
  wire signed [63:0] wPNEG2  = p1p::PNEG2;
  wire signed [63:0] wPNARR  = p1p::PNARR;
  wire signed [63:0] wPBY    = p1p::PBY;
  wire signed [63:0] wPU8    = p1p::PU8;
  wire signed [63:0] wPNAME  = p1p::PNAME;
  wire signed [63:0] wPPAR   = p1p::PPAR;
  wire signed [63:0] wCMUL   = p1p::CMUL;
  wire signed [63:0] wCADD   = p1p::CADD;
  wire signed [63:0] wCLIT   = p1p::CLIT;
  wire signed [63:0] wAPOWL  = p1p::APOWL;
  wire signed [63:0] wCPOWC  = p1p::CPOWC;
  wire        [63:0] wUPOW   = p1p::CPOW;
  wire signed [31:0] wNPOW   = p1p::CPOW;
  assign o = wCPOW ^ wCPOW0 ^ wCPOW1 ^ wCPOWZ ^ wCPOWO ^ wPBIG40 ^ wPBIG62 ^
             wPB63 ^ wPB64 ^ wPB70 ^ wP339 ^ wP340 ^ wP527 ^ wP723 ^ wP1019 ^
             wPNEG ^ wPNEG2 ^ wPNARR ^ wPBY ^ wPU8 ^ wPNAME ^ wPPAR ^
             wCMUL ^ wCADD ^ wCLIT ^ wAPOWL ^ wCPOWC ^ wUPOW ^ {wNPOW, wNPOW};
endmodule
