// § newArrayArgPathElemsStripped200
class H;
  int q[$];
endclass
class C;
  H h;
  logic [7:0] data[];
  task t(ref logic [7:0] bytes[]);
    bytes = new[h.q.size * 2];
    bytes = new[this.data.size - 1](bytes);
  endtask
endclass
module z01; endmodule
