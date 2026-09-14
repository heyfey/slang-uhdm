package pk;
  typedef struct packed {
    int unsigned sidWidth;
    int unsigned dataWidth;
  } user_cfg_t;
  typedef struct packed {
    user_cfg_t   u;
    int unsigned derived;
  } cfg_t;
  function automatic user_cfg_t mku();
    user_cfg_t c;
    c.sidWidth  = 3;
    c.dataWidth = 32;
    return c;
  endfunction
  function automatic cfg_t build(user_cfg_t uu);
    cfg_t c;
    c.u       = uu;
    c.derived = uu.dataWidth * 2;
    return c;
  endfunction
  localparam user_cfg_t UCFG = mku();
  localparam cfg_t      CFG  = build(UCFG);
endpackage

// v6 — a UNION member and an ARRAY member in the path, plus a whole-struct
// member read.
package pk3;
  typedef union packed {
    logic [7:0] a;
    logic [7:0] b;
  } un_t;
  typedef struct packed {
    un_t         un;
    logic [3:0][3:0] arr;
    int unsigned tail;
  } wide_t;
  function automatic wide_t mkw();
    wide_t c;
    c.un   = 8'hA5;
    c.arr  = 16'h1234;
    c.tail = 7;
    return c;
  endfunction
  localparam wide_t WCFG = mkw();
endpackage

module dut #(
    parameter pk3::wide_t WC = pk3::WCFG,
    parameter pk::cfg_t   CFG = pk::CFG
) (
    output logic o
);
  localparam int             UA = WC.un.a;    // through a packed UNION
  localparam logic [15:0]    AA = WC.arr;     // a packed-array member
  localparam int             TT = WC.tail;    // a plain int member after them
  localparam pk::user_cfg_t  SS = CFG.u;      // WHOLE STRUCT member read
  assign o = ^{UA[0], AA[0], TT[0], SS.sidWidth[0]};
endmodule
