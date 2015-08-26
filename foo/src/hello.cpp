#include "config.h"
#include <errno.h>
#include <unistd.h> // readlink()

#ifdef HAVE__NSGETEXECUTABLEPATH
#include <mach-o/dyld.h> // _NSGetExecutablePath()
#endif

#include <algorithm> // min()
#include <cassert>
#include <cstring> // strerror()
#include <iostream>
#include <sstream>
#include <stdexcept>
#include <string>
#include "one_true_makefile/tinyxml2/tinyxml2.h"

// <rant>
// Please note that hello.hpp is intentionally in src/, and not
//   include/.  The reason is because the purpose of include/
//   directories is NOT to provide an organizational scheme to group
//   .hpp and .h files.  Rather, its purpose is to expose interfaces
//   to other modules or programs.  Since we are not exposing the
//   contents of hello.cpp to any other programs or modules, we are
//   not exposing its interface, and thus we are not putting hello.hpp
//   in an include directory.
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

  std::string binPrefix();
  void load(tinyxml2::XMLDocument & doc,
	    const std::string & filename);
  const tinyxml2::XMLNode * getChild(const tinyxml2::XMLNode * const parent,
				     const char * const name =NULL,
				     const size_t index =0);
  std::string getWord(const tinyxml2::XMLDocument & doc,
		      const size_t index);
}

using namespace std;


// Definitions:

/// This is a dumb little demo function that opens an XML document and
///   returns the value of some particular node.  (We expect this to
///   be "Hello".)
std::string word0()
{
  // Infer our XML filename.
  const string filename = ::binPrefix() 
    + "/share/one_true_makefile/foo/hello.xml";

  // Open our doc.
  tinyxml2::XMLDocument doc;
  ::load(doc, filename);

  // Find the value of the text node that is a child of /content/word.
  return ::getWord(doc, 0);

} // word0()


/// This is a dumb little demo function that simply returns the word
///   "world".
std::string word1()
{
  return std::string("world");

} // word1()


namespace {

  // Return the prefix directory, assuming that the current executable
  //   is located in a bin subdirectory.  For example, if this
  //   executable is /usr/local/bin/blah, then binPrefix() will return
  //   "usr/local".
  std::string binPrefix()
  {
    const size_t BUFFSIZE = 1000;
    char buff[BUFFSIZE];
    size_t endIndex;

#ifdef HAVE__NSGETEXECUTABLEPATH

    // Use _NSGetExecutablePath() to find the location of the current running
    //   executable.
    
    assert(BUFFSIZE <= numeric_limits<uint32_t>::max());
    uint32_t len = BUFFSIZE;
    if(_NSGetExecutablePath(buff, &len)) {
      throw runtime_error("Buffer size too small for executable path name.");
    }
    assert(BUFFSIZE>0);
    endIndex = std::min(static_cast<size_t>(len-1), BUFFSIZE-1);

#elif defined(HAVE_PROC_SELF_EXE)
    
    // Use /proc to find the location of the current running executable.

    ssize_t len = readlink("/proc/self/exe", buff, BUFFSIZE);
    if(-1 == len) {
      ostringstream oss;
      oss << "binPrefix(): Error calling readlink(): " << strerror(errno);
      throw runtime_error(oss.str());
    }
    assert(BUFFSIZE>0);
    endIndex = std::min(static_cast<size_t>(len-1), BUFFSIZE-1);

#else
    throw runtime_error("On Linux, we can find config files using"
			" /proc/self/exe, and on OS X we can use"
			" _NSGetExecutablePath(), but neither of those seem to"
			" apply here.  (I wouldn't worry about it; this is just"
			" a 'hello, world' program.)");
#endif

    // This shouldn't be necessary, but let's be paranoid.
    buff[endIndex] = '\0';

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


  // Open the XMLDocument and throw an exception if there's an error.
  void load(tinyxml2::XMLDocument & doc,
	    const std::string & filename)
  {
    if(tinyxml2::XML_NO_ERROR != doc.LoadFile(filename.c_str())) {
      string err = "Error loading file: ";
      err += filename;
      throw runtime_error(err);
    }
  } // ::load()


  // Find a particular child of the specified node.  If name is not
  //   null, getChild() will return an XMLElement with that particular
  //   name.  If index is not zero, then assuming that there are at
  //   least that many matches, getChild() will return that match.
  const tinyxml2::XMLNode * getChild(const tinyxml2::XMLNode * const parent,
				     const char * const name /*=NULL*/,
				     const size_t index /*=0*/)
  {
    const tinyxml2::XMLNode * child;

    // If the user specified a particular node name, we have to use
    //   FirstChildElement(), but if name is NULL, we have
    //   FirstGetChild(), instead of just passing NULL to
    //   FirstChildElement().  This is because passing NULL to
    //   FirstChildElement() means "Give me the first child element,
    //   with any name," which is not what we want, since we don't
    //   just want child elements.  Instead, if name is NULL, we'd
    //   also like to get child nodes which are not elements
    //   (e.g. text nodes), and which would therefore not be caught by
    //   GetChildElement().  (In other words, GetChildElement()
    //   returns XMLElements, not XMLNodes.)
    if(name) {
      child = parent->FirstChildElement(name);
      if(!child) {
	throw runtime_error(string("Unable to find child element named ")+name);
      }
      for(size_t i=1; i<index+1; ++i) {
	child = child->NextSiblingElement(name);
	if(!child) {
	  ostringstream oss;
	  oss << "Only " << i << (i>1?" elements":" element") << " named "
	      << name << "found";
	  throw runtime_error(oss.str());
	}
      }
    }

    else {
      child = parent->FirstChild();
      if(!child) {
	throw runtime_error("Unable to find any child nodes");
      }
      for(size_t i=1; i<index+1; ++i) {
	child = child->NextSibling();
	if(!child) {
	  ostringstream oss;
	  oss << "Only " << i << (i>1?" nodes":" node") << " found";
	  throw runtime_error(oss.str());
	}
      }
    }

    return child;

  } // ::getChild()


  // Walk down an XML document, and find the value of the text node
  //   that is a child of the /content/word element.
  std::string getWord(const tinyxml2::XMLDocument & doc,
		      const size_t index)
  {
    const tinyxml2::XMLNode * const content = ::getChild(&doc, "content");
    const tinyxml2::XMLNode * const word = ::getChild(content, "word", index);
    const tinyxml2::XMLNode * const text  = ::getChild(word);
    const tinyxml2::XMLText * const asText = text->ToText();
    if(!asText) {
      throw runtime_error("Error converting word child to text");
    }

    return string(asText->Value());

  } // ::getWord()
  
} // anonymous namespace

