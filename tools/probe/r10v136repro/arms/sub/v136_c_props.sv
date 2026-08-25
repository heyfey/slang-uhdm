// v136 arm C — the PROPERTY KIND dimension over a packed-struct face.
package Pk_Props;
  typedef struct packed { bit [7:0] regLo; bit [7:0] regHi; } regPair_S;
  typedef union  packed { bit [15:0] uWhole; bit [15:0] uAlt; } uPair_S;

  class PropKinds;
    regPair_S              c01_plain;
    static regPair_S       c02_static;
    rand regPair_S         c03_rand;
    randc bit [3:0]        c04_randcbit;
    local regPair_S        c05_local;
    protected regPair_S    c06_prot;
    local static regPair_S c07_locstat;
    protected rand regPair_S c08_protrand;
    const regPair_S        c09_const = '{regLo:8'd1, regHi:8'd2};
    regPair_S              c10_init = '{regLo:8'd3, regHi:8'd4};
    regPair_S              c11_fixed [4];
    regPair_S              c12_queue [$];
    regPair_S              c13_dyn   [];
    regPair_S              c14_assoc [string];
    regPair_S              c15_two, c16_three;
    uPair_S                c17_uplain;
    rand uPair_S           c18_urand;
    uPair_S                c19_ufixed [2];
    regPair_S              c20_multidim [2][3];
  endclass
endpackage
