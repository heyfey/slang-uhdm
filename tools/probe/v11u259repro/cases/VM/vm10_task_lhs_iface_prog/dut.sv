// § cloneMemberImporterListing259 (a task writing the member, a program the last importer)
package p;
  typedef struct { string path; int offset; } slice_t;
  task t();
    slice_t slice;
    slice.offset = 3;
    slice.path = "a";
  endtask
endpackage
package q;
  import p::*;
endpackage
program pr;
  import p::*;
endprogram
module top;
endmodule
