// r10v168repro/v4_neg168.sv — MEASUREMENT ONLY.  NEGATIVE CONTROLS: not one
// cell here may move.  No enum reaches any of these parameters' init chains
// (or the chain is broken by something the law must respect), and the file
// also carries specparams, struct/array/typedef params and a module-only
// population that the `(inPackage||isImported) && typedParam && topView` gate
// must keep its hands off.
package rowel_pkg;
  typedef enum { SALLOW_NIL, SALLOW_ONE } sallow_e;

  // plain literals of every base and sign, no enum anywhere
  parameter int          n_dec32  = 1234;            // v401
  parameter int          n_neg    = -77;             // v402
  parameter bit [15:0]   n_hex    = 16'hBEEF;        // v403
  parameter bit [15:0]   n_bin    = 16'b1010_1100_0011_0101; // v404
  parameter bit [15:0]   n_oct    = 16'o76543;       // v405
  parameter bit [15:0]   n_bdec   = 16'd4095;        // v406
  parameter logic [7:0]  n_unk    = 8'bxxxx_zzzz;    // v407
  parameter              n_ubz    = 'z;              // v408
  parameter              n_ub1    = '1;              // v409
  parameter string       n_str    = "tredille";      // v410
  parameter real         n_real   = 6.0221e23;       // v411
  parameter time         n_time   = 40ns;            // v412

  // chains of parameters that never reach an enum
  parameter int          n_srcA   = 16'd200;
  parameter int          n_hopA   = n_srcA;          // v413
  parameter int          n_hopB   = n_hopA;          // v414
  parameter bit [7:0]    n_srcH   = 8'hC3;
  parameter bit [7:0]    n_hopH   = n_srcH;          // v415 paramOriginBaseRecode
  parameter bit [7:0]    n_hopH2  = n_hopH;          // v416

  // aggregate / typedef'd parameter types
  typedef struct packed { logic [3:0] a; logic [3:0] b; } pair_t;
  parameter pair_t       n_struct = '{a:4'h5, b:4'hA}; // v417
  parameter int          n_arr[3] = '{1, 2, 3};        // v418
  typedef logic [11:0]   dozen_t;
  parameter dozen_t      n_tdef   = 12'h7FF;           // v419

  // an enum member reached only through a CAST or an operation (broken chain)
  parameter int          n_cast   = int'(SALLOW_ONE);  // v420
  parameter int          n_op     = SALLOW_ONE + 0;    // v421
  parameter int          n_cond   = SALLOW_ONE ? 3 : 4;// v422
endpackage

module Skep_neg #(parameter int P_TOP = 9) (input logic clk, output logic q);
  // module-LOCAL parameters (not imported): the gate must never reach these
  typedef enum { TASSEL_NIL, TASSEL_ONE, TASSEL_TWO } tassel_e;
  localparam tassel_e  n_mod_auto = TASSEL_TWO;      // v423
  localparam int       n_mod_int  = TASSEL_TWO;      // v424
  localparam bit [7:0] n_mod_hex  = 8'h5A;           // v425
  specparam            n_spec_d   = 12;              // v426
  specparam            n_spec_h   = 8'h0F;           // v427

  assign q = clk ^ (|{n_mod_auto, P_TOP[0]});
endmodule
