fmt-all:
	tofu fmt -recursive modules/nodes/*.tf
	tofu fmt -recursive modules/controllers/*.tf
	tofu fmt -recursive example/*.tf

checks: fmt-all # 59
	tfsec .