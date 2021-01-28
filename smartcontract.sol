pragma solidity ^ 0.4.24;

contract smartcontract{
    struct Company {
        string name;
        mapping(string => uint) assets;
        mapping(string => uint) debt;
        bool valid;
    }   
    struct Transaction {
        string from;
        string to;
        uint amount;
        uint time;
        Event event_type;
        string event_detail;
    }
    enum Event {
        buy,
        loan,
        pay
    }
    mapping(string => Company) private str_to_company;
    Company[] private companys;
    Transaction[] private transactions;

    function min(uint a,uint b) private pure returns(uint) {
        if (a <= b) { return a; }
        else { return b; }
    }

    function register(string memory name) public returns(bool) {
        Company storage c = str_to_company[name];
        if (c.valid) { return false; }
        c.name = name;
        c.valid = true;
        companys.push(c);
        return true;
    }

    function deal(string memory from,string memory to,uint amount,Event event_type,string memory event_detail) public returns(bool) {
        Company storage c_from = str_to_company[from];
        Company storage c_to = str_to_company[to];
        if (!c_from.valid || !c_to.valid) { return false; }

        if (event_type == Event.buy || event_type == Event.loan) {
            c_from.debt[to] += amount;
            c_to.assets[from] += amount;
        }
        else {
            if (amount > min(c_from.debt[to],c_to.assets[from])) { return false; }
            c_from.debt[to] -= amount;
            c_to.assets[from] -= amount;
        }

        Transaction memory t;
        t.from = from;
        t.to = to;
        t.amount = amount;
        t.time = now;
        t.event_type = event_type;
        t.event_detail = event_detail;
        transactions.push(t);

        return true;
    }

    function transfer(string memory self,string memory company_assets,string memory company_debt,uint amount) public returns(bool) {
        Company storage c = str_to_company[self];
        if (amount > min(c.assets[company_assets],c.debt[company_debt])) { return false; }
        deal(company_assets,self,amount,Event.pay,"transfer");
        deal(self,company_debt,amount,Event.pay,"transfer");
        deal(company_assets,company_debt,amount,Event.loan,"transfer");
        return true;
    }

    function check_121_assets(string memory self,string memory company_assets) public view returns(uint) {
        return str_to_company[self].assets[company_assets];
    }

    function check_121_debt(string memory self,string memory company_debt) public view returns(uint) {
        return str_to_company[self].debt[company_debt];
    }

    function check_total_assets(string memory self) public view returns(uint) {
        uint sum = 0;
        for (uint i = 0;i < companys.length;i++) {
            sum += check_121_assets(self,companys[i].name);
        }
        return sum;
    }

    function check_total_debt(string memory self) public view returns(uint) {
        uint sum = 0;
        for (uint i = 0;i < companys.length;i++) {
            sum += check_121_debt(self,companys[i].name);
        }
        return sum;
    }

    function get_transactions_size() public view returns(uint) {
        return transactions.length;
    }

    function get_transaction_by_index(uint i) public view returns(string memory,string memory,uint,uint,Event,string memory) {
        Transaction storage t = transactions[i];
        return (t.from,t.to,t.amount,t.time,t.for_event,t.event_detail);
    }

    function get_companys_size() public view returns(uint) {
        return companys.length;
    }

    function get_company_by_index(uint i) public view returns(string memory name) {
        return companys[i].name;
    }

    function inquire_company_in_companys(string memory goal) public view returns(bool) {
        return str_to_company[goal].valid;
    }
}
