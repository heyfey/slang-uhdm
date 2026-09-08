// EXPLICIT (non-wildcard) import of a class name -- does the file unit publish
// the class key for it?  § 206 records only WildcardImport.
package pb206;
  class dd206;
    int y;
  endclass
  typedef dd206 yy206;
endpackage

import pb206::dd206;

module tb206;
  dd206 h;
  initial h = new();
endmodule
