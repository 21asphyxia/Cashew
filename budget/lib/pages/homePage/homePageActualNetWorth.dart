import 'package:budget/colors.dart';
import 'package:budget/database/tables.dart';
import 'package:budget/functions.dart';
import 'package:budget/pages/homePage/homePageNetWorth.dart';
import 'package:budget/pages/transactionFilters.dart';
import 'package:budget/pages/walletDetailsPage.dart';
import 'package:budget/struct/databaseGlobal.dart';
import 'package:budget/struct/settings.dart';
import 'package:budget/widgets/framework/popupFramework.dart';
import 'package:budget/widgets/navigationFramework.dart';
import 'package:budget/widgets/openBottomSheet.dart';
import 'package:budget/widgets/transactionsAmountBox.dart';
import 'package:budget/widgets/util/keepAliveClientMixin.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePageActualNetWorth extends StatelessWidget {
  const HomePageActualNetWorth({super.key});

  @override
  Widget build(BuildContext context) {
    return KeepAliveClientMixin(
      child: StreamBuilder<List<TransactionWallet>>(
          stream: database
              .getAllPinnedWallets(HomePageWidgetDisplay.ActualNetWorth)
              .$1,
          builder: (context, snapshot) {
            if (snapshot.hasData ||
                appStateSettings["netWorthAllWallets"] == true) {
              List<String>? walletPks =
                  (snapshot.data ?? []).map((item) => item.walletPk).toList();
              if (walletPks.length <= 0 ||
                  appStateSettings["netWorthAllWallets"] == true)
                walletPks = null;
              return Padding(
                padding: const EdgeInsetsDirectional.only(
                    bottom: 13, start: 13, end: 13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TransactionsAmountBox(
                        onLongPress: () async {
                          await openActualNetWorthSettings(context);
                          homePageStateKey.currentState?.refreshState();
                        },
                        label: "actual-net-worth".tr(),
                        getTextColor: appStateSettings["netTotalsColorful"] !=
                                true
                            ? null
                            : (double amount) {
                                double? roundedWalletWithTotal =
                                    (double.tryParse(absoluteZero(amount)
                                        .toStringAsFixed(
                                            Provider.of<AllWallets>(context)
                                                    .indexedByPk[
                                                        appStateSettings[
                                                            "selectedWalletPk"]]
                                                    ?.decimals ??
                                                2)));
                                return appStateSettings["netTotalsColorful"] ==
                                        true
                                    ? (roundedWalletWithTotal == 0
                                        ? getColor(context, "black")
                                        : amount > 0
                                            ? getColor(context, "incomeAmount")
                                            : getColor(
                                                context, "expenseAmount"))
                                    : getColor(context, "black");
                              },
                        absolute: false,
                        currencyKey: Provider.of<AllWallets>(context)
                            .indexedByPk[appStateSettings["selectedWalletPk"]]
                            ?.currency,
                        totalWithCountStream:
                            database.watchTotalWithCountOfWallet(
                          onlyIncomeAndExpense: true,
                          isIncome: null,
                          allWallets: Provider.of<AllWallets>(context),
                          followCustomPeriodCycle: true,
                          cycleSettingsExtension: "ActualNetWorth",
                          searchFilters:
                              SearchFilters(walletPks: walletPks ?? []),
                        ),
                        // getTextColor: (amount) => amount == 0
                        //     ? getColor(context, "black")
                        //     : amount > 0
                        //         ? getColor(context, "incomeAmount")
                        //         : getColor(context, "expenseAmount"),
                        textColor: getColor(context, "black"),
                        openPage: WalletDetailsPage(
                          wallet: null,
                          initialSearchFilters: SearchFilters(
                            dateTimeRange:
                                getDateTimeRangeForPassedSearchFilters(
                              cycleSettingsExtension: "ActualNetWorth",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return SizedBox.shrink();
          }),
    );
  }
}

Future openActualNetWorthSettings(BuildContext context) {
  return openBottomSheet(
    context,
    PopupFramework(
      title: "actual-net-worth".tr(),
      subtitle: "applies-to-homepage".tr() +
          (getPlatform(ignoreEmulation: true) == PlatformOS.isAndroid
              ? " " + "and-applies-to-widget".tr()
              : ""),
      child: WalletPickerPeriodCycle(
        allWalletsSettingKey: "actualNetWorthAllWallets",
        cycleSettingsExtension: "ActualNetWorth",
        homePageWidgetDisplay: HomePageWidgetDisplay.ActualNetWorth,
      ),
    ),
  );
}
