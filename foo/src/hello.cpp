#include <algorithm> // min()
#include <iostream>
#include <stdexcept>
#include "config.h"
#include <errno.h>
#include <unistd.h> // readlink()
#include <cstring> // strerror()
#include <stdexcept>
#include <string>
#define TIXML_USE_STL YES
#include "one_true_makefile/tinyxml/tinyxml.h"

// <rant>
// Please note that hello.hpp is intentionally in src/, and not
//   include/.  The reason is because the purpose of include/
//   directories is NOT to provide an organizational scheme to group
//   .hpp and .h files.  Rather, its purpose is to expose interfaces
//   to other modules or programs.  Since we are not exposing the
//   contents of hello.cpp to any other programs or modules, we are
//   not exposing its interface, and thus we are not putting it in an
//   include directory.
// In contrast, for the tinyxml module, we elect to expose an
//   interface, so it has header files in an include directory.
// Running "make install" will cause the tinyxml headers to be
//   installed, while hello.hpp will not be installed.  This is
//   appropriate because we install the libtinyxml-otm.so library.
//   Since hello.cpp ends up as part of an executable and not part of
//   a shared library, nothing else is ever going to need it after our
//   foo executable is compiled, so this is the correct behavior; we
//   don't want hello.hpp to be installed.  In other words, the
//   hello.hpp file is an "interior" thing, and it is only visible to
//   this module.  Besides reducing complexity for our users, this
//   separates interface from implementation.  We can change hello.hpp
//   however we want, and it won't affect our users at all.
// Note that since hello.hpp is in the same directory as foo.cpp and
//   hello.cpp, the compiler doesn't need any flags in order to find
//   hello.hpp.  (This behavior is dictated by the C++ standard.)
// Well, OK, the test_foo module *does* look at the hello.hpp file,
//   but I consider unit tests to be "internal," in the sense that
//   it's OK if they muck around in the guts of your source code.
//   Unit tests don't get installed, so they're "internal."
// </rant>
#include "hello.hpp"

// Declarations:
namespace {
  TiXmlDocument getDoc(const char * const filename);
  std::string binPrefix();
  const TiXmlNode * getChild(const TiXmlNode * const parent,
			     const char * const name =NULL,
			     const size_t index =0);
  std::string getWord(const TiXmlDocument & doc,
		      const size_t index);
}

using namespace std;


// Definitions:

std::string word0()
{
  const string filename = ::binPrefix() \
    + "/share/one_true_makefile/foo/hello.xml";
  TiXmlDocument doc = ::getDoc(filename.c_str());
  return ::getWord(doc, 0);

} // word0()


std::string word1()
{
  return std::string("world");

} // word1()


namespace {

  TiXmlDocument getDoc(const char * const filename)
  {
    TiXmlDocument doc(filename);
    if(!doc.LoadFile()) {
      string err = "Error loading file: ";
      err += filename;
      throw runtime_error(err);
    }
    return doc;
    
  } // ::getDoc()


  std::string binPrefix()
  {
    const size_t BUFFSIZE = 200;
    char buff[BUFFSIZE];

    // Use /proc to find the location of the current running executable.

#ifndef HAVE_PROC_SELF_EXE
    throw runtime_error("On Linux, we can find config files using"
			" /proc/self/exe, but apparently this isn't Linux."
			"   (I wouldn't worry about it; this is just a 'hello,"
			" world' program.)");
#endif

    ssize_t len = readlink("/proc/self/exe", buff, BUFFSIZE);
    if(-1 == len) {
      ostringstream oss;
      oss << "binPrefix(): Error calling readlink: " << strerror(errno);
      throw runtime_error(oss.str());
    }
    // This shouldn't be necessary, but let's be paranoid.
    len = std::min(static_cast<size_t>(len), BUFFSIZE-1);
    buff[len] = '\0';
    const std::string exe(buff);

    // We assume the prefix is the level level below /bin/.
    size_t binLoc = exe.find("/bin/");
    if(std::string::npos == binLoc) {
      throw runtime_error("binPrefix(): Unable to find occurence of"
			  " string \"/bin/\"");
    }

    // If the first occurence of "/bin/" is at the beginning of the
    //   string, return "/".
    if(0 == binLoc) {
      binLoc = 1;
    }

    return exe.substr(0, binLoc);

  } // ::binPrefix()


  const TiXmlNode * getChild(const TiXmlNode * const parent,
			     const char * const name /*=NULL*/,
			     const size_t index /*=0*/) {
    const TiXmlNode * child;
    if(name) {
      child = parent->FirstChild(name);
      if(!child) {
	throw runtime_error(string("Unable to find child node named")+name);
      }
    }
    else {
      child = parent->FirstChild();
      if(!child) {
	throw runtime_error("Unable to find child node");
      }
    }      

    for(size_t i=1; i<index+1; ++i) {
      child = child->NextSibling(name);
      if(!child) {
	ostringstream oss;
	oss << "Only " << i << (i>1?" nodes":" node") << " named " << name
	    << "found";
	throw runtime_error(oss.str());
      }
    }

    return child;

  } // ::getChild()


  std::string getWord(const TiXmlDocument & doc,
		      const size_t index) {
    const TiXmlNode * const content = ::getChild(&doc, "content");
    const TiXmlNode * const word = ::getChild(content, "word", index);
    const TiXmlNode * const text  = ::getChild(word);
    const TiXmlText * const asText = text->ToText();
    if(!asText) {
      throw runtime_error("Error converting word child to text");
    }
    return string(asText->Value());

  } // ::getWord()
  
} // anonymous namespace

