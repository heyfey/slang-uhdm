// r10uvm154 arm D — ONE, TWO and THREE instances of a module that reads the
// constant, plus an IMPORT-LISTING clone of the home package.  Instance count
// changes how many elaborated listings the const is copied into; the law must
// answer the same in every copy (the head's five row-modes each carry two).
package pk_d154;
   typedef bit [31:0] dm_t;
   typedef enum dm_t { D_ALL = -1, D_SEVEN = 7 } d_cov_e;
endpackage

module leaf_d154 #(parameter int TAG = 0) (output pk_d154::d_cov_e o);
   assign o = pk_d154::D_ALL;
endmodule

module twoinst_d154(output pk_d154::d_cov_e a, output pk_d154::d_cov_e b);
   leaf_d154 #(.TAG(1)) l1 (a);
   leaf_d154 #(.TAG(2)) l2 (b);
endmodule

module importer_d154;
   import pk_d154::*;
   d_cov_e loc;
   initial loc = D_ALL;
endmodule

module top_d154;
   pk_d154::d_cov_e w0, w1, w2, w3;
   leaf_d154 #(.TAG(0)) single (w0);
   twoinst_d154            pair (w1, w2);
   leaf_d154 #(.TAG(9)) third  (w3);
   importer_d154           imp ();
endmodule
