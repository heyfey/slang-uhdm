// § unitTdPureProtoFormalWriter301
typedef struct packed { logic [3:0] a; } s_t;
virtual class c;
  pure virtual task t(input s_t y);
endclass
module dut (output logic [3:0] o);
  task automatic m(input s_t y); o = y.a; endtask
  initial m('0);
endmodule
