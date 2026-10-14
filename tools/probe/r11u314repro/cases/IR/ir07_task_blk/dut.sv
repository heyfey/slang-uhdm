// § ipsBaseNamesReach314
typedef struct packed { logic [7:0] v; } a_t;
module top; a_t a; int ix[4]; task t(input int k); begin : b a.v[ix[k] +: 2] = 0; end endtask endmodule
