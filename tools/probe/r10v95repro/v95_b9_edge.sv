// r10v95 arm b9 — the EDGE shapes: string/handle/event selects, parameter and
// port roots, unsized-inner dimensions, typedef'd unpacked arrays, enum arrays,
// deep chains, and $unit scope.
typedef logic [6:0]  u7_t;
typedef u7_t         u7arr_t [4];
typedef enum bit [1:0] { Z0, Z1, Z2 } z2_t;

class Cap9;
  int celx;
endclass

module leaf9 (input logic [13:0] pin14, output logic [4:0] pout5);
  byte pdyn [];
  int  pv [3];
  int  s [8];
  initial begin
    s[0] = $bits(pin14[2]);
    s[1] = $bits(pin14[9:3]);
    s[2] = $bits(pout5[1]);
    s[3] = $bits(pdyn[0]);
    s[4] = $bits(pv[1]);
  end
endmodule

module b9;
  parameter int NP = 3;
  localparam logic [10:0] PARR [2] = '{11'd1, 11'd2};
  localparam int PSC = 21;

  string    sarr [3];
  string    s1;
  Cap9      harr [2];
  z2_t      earr [5];
  u7arr_t   tarr;
  byte      jag [2][];
  int       q2 [$][$];
  int       ai [int];
  logic [8:0] deep [2][3][4];
  logic [13:0] pin;
  logic [4:0]  pou;

  leaf9 uL (.pin14(pin), .pout5(pou));

  int y [40];
  genvar gi;
  initial begin
    y[0]  = $bits(sarr[1]);
    y[1]  = $bits(s1);
    y[2]  = $bits(harr[0]);
    y[3]  = $bits(earr[2]);
    y[4]  = $bits(tarr[3]);
    y[5]  = $bits(tarr[3][2]);
    y[6]  = $bits(jag[0][1]);
    y[7]  = $bits(q2[0][1]);
    y[8]  = $bits(ai[7]);
    y[9]  = $bits(deep[1][2][3]);
    y[10] = $bits(deep[1][2][3][5]);
    y[11] = $bits(PARR[1]);
    y[12] = $bits(PARR[1][4]);
    y[13] = $bits(uL.pin14[2]);
    y[14] = $bits(pin[3]);
    y[15] = $bits(pou[1]);
    y[16] = $bits(u7arr_t);
    y[17] = 12'($bits(tarr[0]));
  end
  generate
    for (gi = 0; gi < 2; gi++) begin : gl
      localparam int GB = $bits(deep[0][1][2]);
      wire [$bits(tarr[gi])-1:0] gw;
    end
  endgenerate
endmodule
