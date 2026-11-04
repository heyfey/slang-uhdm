// § classTpKeywordTsAtDefault188
class c #(type T = int);
  task t1(output T o);
    T l;
    o = l;
  endtask
endclass
module top;
  c #(int) h;
endmodule
