// § classTpKeywordTsAtDefault188
class c #(type T = logic);
  task t1(output T o);
    T l;
    o = l;
  endtask
endclass
module top; endmodule
