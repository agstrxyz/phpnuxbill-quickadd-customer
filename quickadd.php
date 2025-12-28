<?php 
 register_menu("Add Customer", true, "quickadd", 'AFTER_CUSTOMERS',  'ion ion-person-add');

 function quickadd()
{
	global $ui,$routes,$config, $zero;
	_admin();
    $ui->assign('_system_menu', 'quickadd');
    $admin = Admin::_info();
    $ui->assign('_admin', $admin);
    $ui->assign('routes', $routes);
	$ui->assign('_title', 'Add Customer');
    $pltype = 'Hotspot';
	if ($routes['2'] == 'pppoe') {
        $pltype = 'PPPOE';
	}
    $plans = ORM::for_table('tbl_plans')->where('type', $pltype)->where('enabled', 1)->find_many();
    $ui->assign('plans', $plans);
    
    $zero = 0;
    $usings = explode(',', $config['payment_usings']);
    $usings = array_filter(array_unique($usings));
    if (count($usings) == 0) {
        $usings[] = Lang::T('Cash');
    }
	$ui->assign('usings', $usings);

	if ($routes['2'] == 'add') {
		if ($routes['3'] == 'pppoe') {
            $rdrct = '/pppoe';
        }
        
        $username = alphanumeric(_post('username'), ":+_.@-");
        $fullname = _post('fullname');
        $password = trim(_post('password'));
        $pppoe_username = trim(_post('pppoe_username'));
        $pppoe_password = trim(_post('pppoe_password'));
        $pppoe_ip = trim(_post('pppoe_ip')); 
        $email = _post('email');
        $address = _post('address');
        $ppln = _post('ppln');
        $phonenumber = _post('phonenumber');
        $service_type = _post('service_type');
        $account_type = 'Personal';
        $city = _post('city');
		$using = _post('using');
		
        if ($using == 'Recharge Zero') {
            $zero = 1;
        }
        
		//post Customers Attributes
        $custom_field_names = (array) $_POST['custom_field_name'];
        $custom_field_values = (array) $_POST['custom_field_value'];

        run_hook('add_customer'); #HOOK
        $msg = '';
        if (Validator::Length($username, 55, 2) == false) {
            $msg .= 'Username should be between 3 to 54 characters' . '<br>';
        }
        if ($ppln == '') {
            $msg .= 'Select Package first!' . '<br>';
        }
        if (Validator::Length($fullname, 36, 1) == false) {
            $msg .= 'Full Name should be between 2 to 25 characters' . '<br>';
        }
        if (!Validator::Length($password, 36, 2)) {
            $msg .= 'Password should be between 3 to 35 characters' . '<br>';
        }

        $d = ORM::for_table('tbl_customers')->where('username', $username)->find_one();
        if ($d) {
            $msg .= Lang::T('Account already axist') . '<br>';
        }
			
        if ($msg == '') {
            $d = ORM::for_table('tbl_customers')->create();
            $d->username = $username;
            $d->password = $password;
            $d->pppoe_username = $pppoe_username;
            $d->pppoe_password = $pppoe_password;
            $d->pppoe_ip = $pppoe_ip;
            $d->email = $email;
            $d->account_type = $account_type;
            $d->fullname = $fullname;
            $d->address = $address;
            $d->created_by = $admin['id'];
            $d->phonenumber = Lang::phoneFormat($phonenumber);
            $d->service_type = $service_type;
            $d->city = $city;
            $d->save();
            $plan = ORM::for_table('tbl_plans')->where('enabled', 1)->find_one($ppln);
            $server = $plan['routers'];
            if ($plan['is_radius'] == '1') {
                $server = 'Radius';
            }
			
			// Retrieve the customer ID of the newly created customer
            $customerId = $d->id();
            // Save Customers Attributes details
            if (!empty($custom_field_values)) {
                $totalFields = min(count($custom_field_names), count($custom_field_values));
                for ($i = 0; $i < $totalFields; $i++) {
                    $name = $custom_field_names[$i];
                    $value = $custom_field_values[$i];

                    if (!empty($value)) {
                        $customField = ORM::for_table('tbl_customers_fields')->create();
                        $customField->customer_id = $customerId;
                        $customField->field_name = $name;
                        $customField->field_value = $value;
                        $customField->save();
                    }
                }
            }
            //recharge new customer
			$gateway = $using;
            if (Package::rechargeUser($d['id'], $server, $plan['id'], $gateway, $admin['fullname'])) {
				list($bills, $add_cost) = User::getBills($d['id']);
			}
            // Send welcome message
            if (isset($_POST['send_welcome_message']) && $_POST['send_welcome_message'] == true) {
                $welcomeMessage = Lang::getNotifText('welcome_message');
                $welcomeMessage = str_replace('[[company]]', $config['CompanyName'], $welcomeMessage);
                $welcomeMessage = str_replace('[[name]]', $d['fullname'], $welcomeMessage);
                $welcomeMessage = str_replace('[[username]]', $d['username'], $welcomeMessage);
                $welcomeMessage = str_replace('[[password]]', $d['password'], $welcomeMessage);
                $welcomeMessage = str_replace('[[url]]', APP_URL . '/?_route=login', $welcomeMessage);

                $emailSubject = "Welcome to " . $config['CompanyName'];

                $channels = [
                    'sms' => [
                        'enabled' => isset($_POST['sms']),
                        'method' => 'sendSMS',
                        'args' => [$d['phonenumber'], $welcomeMessage]
                    ],
                    'whatsapp' => [
                        'enabled' => isset($_POST['wa']),
                        'method' => 'sendWhatsapp',
                        'args' => [$d['phonenumber'], $welcomeMessage]
                    ],
                    'email' => [
                        'enabled' => isset($_POST['mail']),
                        'method' => 'Message::sendEmail',
                        'args' => [$d['email'], $emailSubject, $welcomeMessage, $d['email']]
                    ]
                ];

                foreach ($channels as $channel => $message) {
                    if ($message['enabled']) {
                        try {
                            call_user_func_array($message['method'], $message['args']);
                        } catch (Exception $e) {
                            // Log the error dan handle the failure
                            _log("Failed to send welcome message via $channel: " . $e->getMessage());
                        }
                    }
                }
            }
            unset($zero); // Membersihkan variabel global $zero setelah digunakan. Ini sudah BENAR.
            r2(U . 'customers/view/'.$d['id'], 's', Lang::T('Account Created Successfully'));
        } else {
            r2(U . "plugin/quickadd".$rdrct, 'e', $msg);
        }
	}
		
	$ui->display('quickadd.tpl');
} 