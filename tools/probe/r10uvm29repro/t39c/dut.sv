// t39c — the three shapes t39a left unmodelled, each at several spellings:
// REAL literal vpiValue formatting (uvm_tlm_time's `1.0e-12` prints
// REAL:0.000000 through %f), a CONCATENATION, a TIME literal at two
// precisions, and an ASSIGNMENT PATTERN on an assoc-array property.
`timescale 1ns/1ps
package s39c;
  class hc39;
    // REAL literal spellings.
    real r_half   = 1.5;
    real r_exp    = 1.0e-12;
    real r_int    = 3.0;
    real r_big    = 1e6;
    real r_neg    = -2.5;
    // CONCATENATION.
    string c_two  = {"ab", "cd"};
    string c_one  = {"ab"};
    // TIME literals.
    time   t_s    = 9200s;
    time   t_ns   = 5ns;
    time   t_ps   = 7ps;
    realtime t_rt = 1.5ns;
    // ASSIGNMENT PATTERNs.
    int    a_assoc[string] = '{default:0};
    int    a_fixed[3]      = '{1, 2, 3};
    int    a_dyn[]         = '{4, 5};
  endclass
endpackage

module t39c;
  s39c::hc39 h;
  initial h = new();
endmodule
