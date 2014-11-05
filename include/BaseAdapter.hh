#ifndef   __BASE_ADAPTER_HH__
# define  __BASE_ADAPTER_HH__

# include <string>
# include <boost/program_options.hpp>

# define  CONFIG_PATH(file)   "/etc/needbook/notifier/adapters/" file

namespace po = boost::program_options;

namespace Adapters
{
  class BaseAdapter
  {
  public:
    /*!
     * Get the name of the adapter, will also be the name of the AMQP routing key.
     */
    virtual std::string getName() const = 0;
    /*!
     * Add configuration parameters, such as command line options,
     * which the Adapter will be available to retrieve later on.
     * You should override this method in your Adapter.
     */
    virtual void addConfiguration(po::options_description &);
    /*!
     * This function is not virtual because it is not aimed at being overrided.
     * It will secure the environment and your message() function will be called
     * when it is time.
     */
    void handleMessage(const std::string & message);
    /**
     * Careful, if your adapter fails, the message will be lost!
     * Your algorithm must start in this function, you can use whatever you want
     */
    virtual void message(const std::string & message) = 0;
  };
};

#endif
