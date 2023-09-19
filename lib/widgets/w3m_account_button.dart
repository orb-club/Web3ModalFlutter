import 'package:flutter/material.dart';
import 'package:web3modal_flutter/pages/account_page.dart';
import 'package:web3modal_flutter/services/w3m_service/i_w3m_service.dart';
import 'package:web3modal_flutter/theme/theme.dart';
import 'package:web3modal_flutter/utils/util.dart';
import 'package:web3modal_flutter/widgets/buttons/base_button.dart';
import 'package:web3modal_flutter/widgets/buttons/balance_button.dart';
import 'package:web3modal_flutter/widgets/avatars/w3m_account_avatar.dart';
import 'package:web3modal_flutter/widgets/w3m_token_image.dart';

class W3MAccountButton extends StatefulWidget {
  const W3MAccountButton({
    super.key,
    required this.service,
    this.size = BaseButtonSize.regular,
    this.avatar,
  });

  final IW3MService service;
  final BaseButtonSize size;
  final String? avatar;

  @override
  State<W3MAccountButton> createState() => _W3MAccountButtonState();
}

class _W3MAccountButtonState extends State<W3MAccountButton> {
  String? _address;
  String? _tokenImage;
  String _balance = BalanceButton.balanceDefault;
  String? _tokenName;

  @override
  void initState() {
    super.initState();
    _w3mServiceUpdated();
    widget.service.addListener(_w3mServiceUpdated);
  }

  @override
  void dispose() {
    widget.service.removeListener(_w3mServiceUpdated);
    super.dispose();
  }

  void _w3mServiceUpdated() {
    setState(() {
      _address = widget.service.address;
      _tokenImage = widget.service.tokenImageUrl;
      _balance = BalanceButton.balanceDefault;
      if (widget.service.chainBalance != null) {
        _balance = widget.service.chainBalance!.toStringAsPrecision(4);
        _balance = _balance.replaceAll(RegExp(r'([.]*0+)(?!.*\d)'), '');
      }
      _tokenName = widget.service.selectedChain?.tokenName;
    });
  }

  void _onTap() => widget.service.open(
        context: context,
        startWidget: const AccountPage(),
      );

  @override
  Widget build(BuildContext context) {
    final themeData = Web3ModalTheme.getDataOf(context);
    // TODO this button should be able to be disable by passing a null onTap action
    // I should decouple an AccountButton from W3MAccountButton like on ConnectButton and NetworkButton
    return BaseButton(
      size: widget.size,
      onTap: _onTap,
      overridePadding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.only(right: 4.0),
      ),
      buttonStyle: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return themeData.colors.overgray005;
            }
            return themeData.colors.overgray010;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(MaterialState.disabled)) {
              return themeData.colors.overgray015;
            }
            return themeData.colors.foreground175;
          },
        ),
        shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
          (states) {
            return RoundedRectangleBorder(
              side: states.contains(MaterialState.disabled)
                  ? BorderSide(color: themeData.colors.overgray005, width: 1.0)
                  : BorderSide(color: themeData.colors.overgray010, width: 1.0),
              borderRadius: BorderRadius.circular(widget.size.height / 2),
            );
          },
        ),
      ),
      icon: BaseButton(
        size: BaseButtonSize.small,
        onTap: _onTap,
        overridePadding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.only(left: 8.0),
        ),
        buttonStyle: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(MaterialState.disabled)) {
                return themeData.colors.overgray015;
              }
              return themeData.colors.foreground100;
            },
          ),
        ),
        icon: W3MTokenImage(
          imageUrl: _tokenImage,
          size: widget.size.iconSize,
          disabled: false,
        ),
        child: Text('$_balance ${_tokenName ?? ''}'),
      ),
      child: BaseButton(
        size: BaseButtonSize.small,
        onTap: _onTap,
        overridePadding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.only(left: 8.0, right: 8.0),
        ),
        buttonStyle: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(MaterialState.disabled)) {
                return themeData.colors.overgray005;
              }
              return themeData.colors.overgray010;
            },
          ),
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(MaterialState.disabled)) {
                return themeData.colors.overgray015;
              }
              return themeData.colors.foreground175;
            },
          ),
          shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
            (states) {
              return RoundedRectangleBorder(
                side: states.contains(MaterialState.disabled)
                    ? BorderSide(
                        color: themeData.colors.overgray005,
                        width: 1.0,
                      )
                    : BorderSide(
                        color: themeData.colors.overgray010,
                        width: 1.0,
                      ),
                borderRadius:
                    BorderRadius.circular(BaseButtonSize.small.height / 2),
              );
            },
          ),
        ),
        icon: W3MAccountAvatar(
          service: widget.service,
          size: widget.size.iconSize,
          disabled: false,
        ),
        child: Text(Util.truncate(_address ?? '')),
      ),
    );
  }
}
