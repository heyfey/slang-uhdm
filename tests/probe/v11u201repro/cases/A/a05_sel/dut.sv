// § newArrayArgPathElemsStripped200
typedef struct { int n; } e_t;
class K;
  e_t a[4];
  byte d[];
  task t(int i);
    d = new[a[i].n];
    d = new[a[1].n + 2];
  endtask
endclass
module top;
  K k;
  initial begin k = new; k.t(1); end
endmodule
