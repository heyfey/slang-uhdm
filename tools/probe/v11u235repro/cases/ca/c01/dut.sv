// § clsTdAnchorAliasQualName235
package p;
class outer;
  class cb #(type T=int);
    typedef cb#(T) this_type;
    static this_type m_inst;
  endclass
endclass
typedef outer::cb#(int) ocb_t;
endpackage
module top;
endmodule
