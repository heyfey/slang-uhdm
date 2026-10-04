// § unitClsAggTdLastWriter235
typedef struct packed { logic [3:0] a; logic b; } uk_t;
class other;
  typedef struct { int a; bit [7:0] b; } os_t;
  typedef logic [3:0] ov_t;
endclass
class env;
  typedef struct { int x; other::ov_t y; } es_t;
  es_t m;
  other::os_t n;
  uk_t k;
endclass
module top(output [4:0] o);
  uk_t s;
  assign o = s;
endmodule
