// r10v168repro/v3_home168.sv — MEASUREMENT ONLY.
// FACE: WHERE the parameter lives — a package, a package that imports another,
// a module (its own parameter, a materialized wildcard import, an explicit
// import, a child instance's ACTUAL), an interface, a class (in a package and
// standalone), a flat and a nested generate scope, and $unit — each reading
// the SAME auto-numbered / based-decimal / octal members.  DEF and ELAB views
// are both read by the census.
package tundish_pkg;
  typedef enum { HAULM_NIL, HAULM_ONE, HAULM_TWO, HAULM_TRI } haulm_e;
  typedef enum bit [7:0] { INGLE_D = 8'd21, INGLE_NX } ingle_e;
  typedef enum logic [5:0] { JOWL_O = 6'o31, JOWL_NX } jowl_e;

  parameter haulm_e h_pkg_auto = HAULM_TRI;   // v301 package own listing
  parameter ingle_e h_pkg_bdec = INGLE_D;     // v302
  parameter jowl_e  h_pkg_oct  = JOWL_O;      // v303
  parameter ingle_e h_pkg_anx  = INGLE_NX;    // v304

  // a class inside a package, with a class-scoped enum
  class Kist_c;
    typedef enum { LEDE_NIL, LEDE_ONE, LEDE_TWO } lede_e;
    localparam lede_e h_cls_auto = LEDE_TWO;  // v305 class-scope localparam
    localparam int    h_cls_int  = LEDE_TWO;  // v306
  endclass

  // a package parameter that reads the CLASS-scoped member
  parameter int h_pkg_clsref = int'(Kist_c::LEDE_TWO); // v307 (cast: control)
endpackage

package mullion_pkg;
  import tundish_pkg::*;
  // a package importing another package's enum
  parameter haulm_e h_imp_auto = HAULM_TWO;               // v308
  parameter int     h_imp_scop = tundish_pkg::HAULM_TWO;  // v309
  parameter ingle_e h_imp_bdec = INGLE_D;                 // v310
endpackage

// $unit-scope
import tundish_pkg::*;
parameter haulm_e h_unit_auto = HAULM_ONE;                // v311

interface Nacelle_if;
  import tundish_pkg::*;
  parameter haulm_e h_ifc_auto = HAULM_TRI;               // v312
  parameter ingle_e h_ifc_bdec = INGLE_D;                 // v313
  logic dummy;
endinterface

module Ossuary_child #(parameter tundish_pkg::haulm_e H_ACT = tundish_pkg::HAULM_NIL)
                      (input logic clkc);
  localparam int h_chi_local = H_ACT;                     // v314
endmodule

module Pintle_top(input logic clk);
  import tundish_pkg::*;                                  // wildcard import
  import mullion_pkg::h_imp_auto;                         // explicit import

  parameter haulm_e h_mod_auto = HAULM_TWO;               // v315 module own
  localparam ingle_e h_mod_bdec = INGLE_D;                // v316
  localparam jowl_e  h_mod_oct  = JOWL_O;                 // v317

  // child instance parameter ACTUAL is an enum member
  Ossuary_child #(.H_ACT(HAULM_TRI)) u_kid (.clkc(clk));  // v318

  Nacelle_if u_ifc();

  // flat generate scope
  generate
    if (1) begin : g_flat
      localparam haulm_e h_gen_auto = HAULM_TRI;          // v319
      localparam ingle_e h_gen_bdec = INGLE_D;            // v320
    end
  endgenerate

  // nested generate scope, and a genvar loop
  generate
    for (genvar gi = 0; gi < 2; gi++) begin : g_loop
      if (gi == 0) begin : g_inner
        localparam haulm_e h_nest_auto = HAULM_TWO;       // v321
      end
      localparam int h_loop_int = HAULM_ONE;              // v322
    end
  endgenerate

  // a standalone class in a module
  class Quirt_c;
    typedef enum bit [3:0] { RIVE_D = 4'd6, RIVE_NX } rive_e;
    localparam rive_e h_mcls_bdec = RIVE_D;               // v323
    localparam rive_e h_mcls_auto = RIVE_NX;              // v324
  endclass

  // a function-scope localparam
  function automatic int sift_f();
    localparam haulm_e h_fun_auto = HAULM_ONE;            // v325
    return int'(h_fun_auto);
  endfunction

  logic [3:0] sink;
  always_comb sink = 4'(sift_f());
endmodule
