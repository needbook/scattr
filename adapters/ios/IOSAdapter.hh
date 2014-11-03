#ifndef   __IOS_ADAPTER_HH__
# define  __IOS_ADAPTER_HH__

# include <string>
# include "BaseAdapter.hh"

namespace Adapters
{
  class IOSAdapter : public BaseAdapter
  {
    std::string getName() const;
    void addConfiguration(po::options_description &);
  };
};

#endif