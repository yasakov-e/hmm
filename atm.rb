require 'yaml'

config = YAML.load_file(ARGV.first || 'config.yml')

b = config["banknotes"]
accounts = config["accounts"]
@current_user = nil
@logged_in = false
@balance_changed = false


def max_amount(b)
    sum = 0
    b.each_pair {|key,val| sum += val * key}
    return sum
end

def LogIn(accounts)
    puts("\nPlease enter your account number:")
    login = STDIN.gets.chomp.to_i
    puts("Please enter your password:")
    password = STDIN.gets.chomp
 
   
    if (accounts.has_key?(login) && accounts[login]["password"].eql?(password) ) #in Windows comparing is not working correctly with Iryna`s password, probably some encoding problems
        then
        @current_user = accounts[login]
        @logged_in = true
        return puts("\nHello, #{accounts[login]["name"]}") 
        end
        return puts("ERROR: ACCOUNT NUMBER AND PASSWORD DON'T MATCH")

end

def getUserInput
    loop do
    value = Integer(STDIN.gets) rescue false
    return value if value && (value > 0)
    puts("\nOnly integer numbers, please!")
    end
end

def make_copy(first,second)
    first.each_pair {|key,value|
    second[key] = value
    }
end
def withdraw(b,accounts)
    loop do
        puts("Enter Amount You Wish to Withdraw:")
        value = val = getUserInput
        max = max_amount(b)

        tmp_b = Hash.new
        restore = {}
        i = 0
        make_copy(b,tmp_b)
        make_copy(tmp_b,restore)

        return puts("You don`t have enough funds on your balance") if (value > @current_user["balance"])
        return puts("Maximum amount available in this ATM is#{max}, please enter a smaller value") if(value > max)

        while !tmp_b.empty? do
        i += 1
        val = value
            tmp_b.each_key {|key|
            until(val<key || tmp_b[key] == 0) do
                val -= key
                tmp_b[key] -= 1
            end
            }
            
            if(val == 0)
            then
                tmp_b.each_key {|key|
                b[key] = tmp_b[key]
                }
                @current_user["balance"] -= value
                accounts.update(@current_user)
                @balance_changed = true
                return puts("Your new balance is #{@current_user["balance"]}")
            else
            make_copy(restore,tmp_b)
            i.times {tmp_b.shift}
            end
        end
        return puts("ERROR: THE AMOUNT YOU REQUESTED CANNOT BE COMPOSED FROM BILLS AVAILABLE IN THIS ATM. PLEASE ENTER A DIFFERENT AMOUNT:")
    
    end
    
end

loop do
    LogIn(accounts)
    next if @logged_in == false
    loop do
    break if @logged_in == false
        puts("\nPlease Choose From the Following Options:
        1. Display Balance
        2. Withdraw
        3. Log Out")
        @balance_changed = false;
        choice = STDIN.gets.chomp.to_i
        case choice
        when 1
            puts("\nYour Current Balance is ₴#{@current_user["balance"]}")
        when 2 
            loop do
                break if @balance_changed
            withdraw(b,accounts)
            print b
            end
        when 3
            puts("\nHave a nice day,#{@current_user["name"]}")
            @current_user = nil
            @logged_in = false
        else
            puts("\nInput either 1, 2 or 3!")
        end
    end

end