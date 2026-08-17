interface itf #(parameter int AW = 16);
  typedef enum logic [AW-1:0] { E0, E1 } e_t;
  e_t            e;
  logic [AW-1:0] a;
  real           r;
  string         st;
  event          ev;
  modport mp (input a, e);
endinterface
module recv #(parameter int AW = 5)(itf.mp p[3]);
endmodule
module top;
  itf #(8) arr[3]();
  recv u (.p(arr));
endmodule
