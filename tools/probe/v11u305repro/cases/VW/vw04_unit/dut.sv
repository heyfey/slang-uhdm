// § wireScopedTdPkgOnly305v
typedef struct packed { logic [2:0] a; logic [2:0] b; } sa_t;
module top (input sa_t t, output logic [2:0] o);
  wire $unit::sa_t sn;
  assign sn = t;
  assign o = sn.a;
endmodule
