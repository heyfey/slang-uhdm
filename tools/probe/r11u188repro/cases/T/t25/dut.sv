// § classTpKeywordTsAtDefault188
class c #(type T = int);
  task t1(output T o);
    T l;
    o = l;
  endtask
  task t2(output T o2, input int k);
    o2 = k;
  endtask
endclass
module top; endmodule
