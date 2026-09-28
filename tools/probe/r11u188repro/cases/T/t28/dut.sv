// § classTpKeywordTsAtDefault188
package p;
class c #(type T = string);
  task t1(output T o);
    T l;
    o = l;
  endtask
endclass
endpackage
module top; endmodule
