{include file="sections/header.tpl"}

<form class="form-horizontal" method="post" role="form" action="{$_url}plugin/quickadd/add{if $routes['2'] == 'pppoe'}/pppoe{/if}">
    <input type="hidden" name="csrf_token" value="{$csrf_token}">
    <div class="row">
        <div class="col-md-6">
            <div class="panel panel-primary panel-hovered panel-stacked mb30">
					<ul class="nav nav-tabs">
						<li role="presentation" {if $routes['2'] eq ''}class="active"{/if}>
							<a href="{$_url}plugin/quickadd" aria-controls="plugin" style="border-radius: 20px 6px 0 0">{Lang::T('Hotspot')}</a></li>
						<li role="presentation" {if $routes['2'] eq 'pppoe'}class="active"{/if}>
							<a href="{$_url}plugin/quickadd/pppoe">{Lang::T('PPPoE')}</a>
						</li>
					</ul>
                <div class="panel-heading">{Lang::T('Add New customer')}</div>
                <div class="panel-body">
				<input type="hidden" name="account_type" value="Hotspot">
                    <div class="form-group">
                        <label class="col-md-3 control-label">{Lang::T('Username')}</label>
                        <div class="col-md-9">
                            <div class="input-group">
                                {if $_c['country_code_phone'] != ''}
                                    <span class="input-group-addon" id="basic-addon1"><i
                                            class="glyphicon glyphicon-phone-alt"></i></span>
                                {else}
                                    <span class="input-group-addon" id="basic-addon1"><i
                                            class="glyphicon glyphicon-user"></i></span>
                                {/if}
                                <input type="text" class="form-control" name="username" required
                                    placeholder="{if $_c['country_code_phone']!= ''}{$_c['country_code_phone']} {Lang::T('Phone Number')}{else}{Lang::T('Username')}{/if}">
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 control-label">{Lang::T('Full Name')}</label>
                        <div class="col-md-9">
                            <input type="text" required class="form-control" id="fullname" name="fullname">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 control-label">{Lang::T('Email')}</label>
                        <div class="col-md-9">
                            <input type="email" class="form-control" id="email" name="email">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 control-label">{Lang::T('Phone Number')}</label>
                        <div class="col-md-9">
                            <div class="input-group">
                                {if $_c['country_code_phone']!= ''}
                                    <span class="input-group-addon" id="basic-addon1">+</span>
                                {else}
                                    <span class="input-group-addon" id="basic-addon1"><i
                                            class="glyphicon glyphicon-phone-alt"></i></span>
                                {/if}
                                <input type="text" class="form-control" name="phonenumber"
                                    placeholder="{if $_c['country_code_phone']!= ''}{$_c['country_code_phone']}{/if} {Lang::T('Phone Number')}">
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 control-label">{Lang::T('Password')}</label>
                        <div class="col-md-9">
                            <input type="password" class="form-control" autocomplete="off" required id="password"
                                value="{rand(000000,999999)}" name="password" onmouseleave="this.type = 'password'"
                                onmouseenter="this.type = 'text'">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 control-label">{Lang::T('Address')}</label>
                        <div class="col-md-9">
                            <textarea name="address" id="address" class="form-control"></textarea>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-md-3 control-label">{Lang::T('Select Package')}</label>
                        <div class="col-md-9">
                            <select class="form-control select2"
                                name="ppln" style="width: 100%" data-placeholder="{Lang::T('Select Package')}...">
						{foreach $plans as $plan}
                        <option value="{$plan['id']}">{$plan['name_plan']} &bull; {Lang::moneyFormat($plan['price'])}{if $plan['routers']} &bull; {$plan['routers']}{/if}</option>
						{/foreach}
                            </select>
                        </div>
                    </div>
                    <div class="panel-heading"></div>
                    <div class="panel-body">
                        <div class="form-group">
                            <label class="col-md-3 control-label">{Lang::T('Send Welcome Message')}</label>
                            <div class="col-md-9">
                                <label class="switch">
                                    <input type="checkbox" id="send_welcome_message" value="1" name="send_welcome_message">
                                    <span class="slider"></span>
                                </label>
                            </div>
                        </div>
                        <div class="form-group" id="method" style="display: none;">
                            <label class="col-md-3 control-label">{Lang::T('Method')}</label>
                            <label class="col-md-3 control-label"><input type="checkbox" name="sms" value="1">
                                {Lang::T('SMS')}</label>
                            <label class="col-md-2 control-label"><input type="checkbox" name="wa" value="1">
                                {Lang::T('WA')}</label>
                            <label class="col-md-2 control-label"><input type="checkbox" name="mail" value="1">
                                {Lang::T('Email')}</label>
                        </div>
                    </div>
                <input type="text" id="service_type" name="service_type" value="{if $routes['2'] eq 'pppoe'}PPPoE{else}hotspot{/if}" hidden>
            </div>
    <center>
        <button class="btn btn-primary" onclick="return ask(this, 'Continue the process of adding Customer Data?')" type="submit">
            {Lang::T('Create Account')}
        </button>
        <br><a href="{$_url}customers" class="btn btn-link">{Lang::T('Cancel')}</a>
    </center>
        </div>
    </div>
</form>
<script>
document.addEventListener('DOMContentLoaded', function() {
    var sendWelcomeCheckbox = document.getElementById('send_welcome_message');
    var methodSection = document.getElementById('method');

    function toggleMethodSection() {
        if (sendWelcomeCheckbox.checked) {
            methodSection.style.display = 'block';
        } else {
            methodSection.style.display = 'none';
        }
    }

    toggleMethodSection();

    sendWelcomeCheckbox.addEventListener('change', toggleMethodSection);
    document.querySelector('form').addEventListener('submit', function(event) {
        if (sendWelcomeCheckbox.checked) {
            var methodCheckboxes = methodSection.querySelectorAll('input[type="checkbox"]');
            var oneChecked = Array.from(methodCheckboxes).some(function(checkbox) {
                return checkbox.checked;
            });

            if (!oneChecked) {
                event.preventDefault();
                alert('Please choose at least one method.');
                methodSection.focus();
            }
        }
    });
});
</script>
{include file="sections/footer.tpl"}
