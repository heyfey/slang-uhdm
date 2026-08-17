// verifier arm C -- USE POSITIONS + spellings for a typedef-based enum, plus
// the packed-dimension-after-name base and signed/unsigned typedef bases.
package pc10;
  typedef bit signed [7:0]   tc_sbit;
  typedef logic signed [7:0] tc_slog;
  typedef bit [7:0]          tc_bit;
  typedef tc_bit             tc_bit_c;

  typedef enum tc_sbit { S0 = 0, S1 = 1 } e_sbit;
  typedef enum tc_slog { T0 = 0, T1 = 1 } e_slog;
  typedef enum tc_bit  { U0 = 0, U1 = 1 } e_bit;

  function automatic e_bit fret10(e_bit arg);
    e_bit loc;
    loc = arg;
    begin
      e_bit nested;
      nested = loc;
      loc = nested;
    end
    return loc;
  endfunction

  typedef struct packed { e_bit f; bit [7:0] g; } sc_t;
  typedef e_bit q_arr [3];

  class cc10 #(parameter type PT = tc_bit);
    typedef enum tc_bit { V0 = 0, V1 = 1 } e_in_param_cls;
    e_in_param_cls pv;
    PT             pw;
  endclass
endpackage

module vcTop10 (input pc10::e_bit pin, output pc10::e_bit pout);
  import pc10::*;
  import pc10::e_slog;
  pc10::e_bit  a1;
  e_bit        a2;   // wildcard-imported spelling
  e_slog       a3;   // explicitly-imported spelling
  pc10::sc_t   a4;
  pc10::q_arr  a5;
  localparam int NB = $bits(pc10::e_bit);
  int a6 = int'(pc10::U1);
  pc10::cc10 #(pc10::tc_bit) a7;
  initial begin
    automatic pc10::e_bit lv = pc10::fret10(pc10::U0);
    foreach (a5[i]) a5[i] = lv;
  end
  assign pout = pin;
endmodule
